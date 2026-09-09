import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 5,
  duration: '3000s',
};

const params = {
    headers: {
      'Content-Type': 'application/json',
      'Host': 'app-service.joshuel.com'
    },
  };
export default function () {
  http.get('http://cluster-ecs-ec2-ingress-251760924.us-east-1.elb.amazonaws.com/system', params);
}